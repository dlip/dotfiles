{
  lib,
  romm,
  rom-converto,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchPypi,
  python3,
}:
let
  pythonPackages = python3.pkgs.overrideScope (
    final: prev: {
      redis = prev.redis.overridePythonAttrs (oldRedis: {
        version = "8.1.0";
        src = fetchPypi {
          pname = "redis";
          version = "8.1.0";
          hash = "sha256-bhoZvu+SJcg+/Wicfmt9otUhWx9CzRO3/DcU0KCceyU=";
        };
        doCheck = false;
        meta = oldRedis.meta // {
          changelog = "https://github.com/redis/redis-py/releases/tag/v8.1.0";
        };
      });
      rq = prev.rq.overridePythonAttrs (oldRq: {
        version = "2.12.0";
        src = fetchPypi {
          pname = "rq";
          version = "2.12.0";
          hash = "sha256-eBFtDIYPYoWBe1LX1tCxanJjcgc86OodIpcyznTvk3g=";
        };
        doCheck = false;
        meta = oldRq.meta // {
          changelog = "https://github.com/rq/rq/releases/tag/v2.12.0";
        };
      });
    }
  );
in
romm.overrideAttrs (
  finalAttrs: old: {
    version = "5.4.0";
    src = fetchFromGitHub {
      owner = "rommapp";
      repo = "romm";
      tag = finalAttrs.version;
      hash = "sha256-oIYEdIAJgXkcqjZtWlWKD/NFiQ3gbo7gxwLhqZOCWpM=";
    };

    passthru = old.passthru // {
      pythonEnv = python3.withPackages (
        _:
        map
          (
            package:
            if (package.pname or "") == "python3" then
              package
            else
              pythonPackages.${package.pname or ""} or package
          )
          (
            builtins.filter (
              package:
              !(builtins.elem (package.pname or "") [
                "rq-scheduler"
                "crontab"
              ])
            ) romm.pythonEnv.paths
          )
        ++ [
          pythonPackages.apprise
          pythonPackages.croniter
          pythonPackages.httpx2
        ]
      );
      frontend = romm.frontend.overrideAttrs {
        inherit (finalAttrs) version;
        src = "${finalAttrs.src}/frontend";
        npmDepsHash = "sha256-f5IcpOVv7JYFzUPkZIq5nbT3dS1f/KCSllh8Vkgl1P0=";
        npmDeps = fetchNpmDeps {
          src = "${finalAttrs.src}/frontend";
          hash = "sha256-f5IcpOVv7JYFzUPkZIq5nbT3dS1f/KCSllh8Vkgl1P0=";
        };
      };
    };

    installPhase =
      builtins.replaceStrings
        [
          "/bin/rqscheduler romm-scheduler"
          ''--add-flags "--path $out/share/romm/backend"''
          "--worker-class handler.rq_worker.RomMWorker high default low"
        ]
        [
          "/bin/rq romm-scheduler"
          ''--add-flags "cron --path $out/share/romm/backend --connection-class handler.redis_handler.RomMRedis tasks.cron_config"''
          "--worker-class handler.rq_worker.PreloadingWorker --connection-class handler.redis_handler.RomMRedis --with-scheduler high default low"
        ]
        old.installPhase;

    postInstall = ''
      for queue in scans streaming; do
        wrap ${finalAttrs.passthru.pythonEnv}/bin/rq "romm-$queue-worker" \
          --add-flags "worker --path $out/share/romm/backend --worker-class handler.rq_worker.PreloadingWorker --connection-class handler.redis_handler.RomMRedis --with-scheduler $queue"
      done
      for program in romm romm-worker romm-scans-worker romm-streaming-worker romm-scheduler romm-watcher romm-startup; do
        wrapProgram "$out/bin/$program" --prefix PATH : ${lib.makeBinPath [ rom-converto ]}
      done
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      ${finalAttrs.passthru.pythonEnv}/bin/python <<'PY'
      from redis.asyncio import Redis
      from redis.maint_notifications import MaintNotificationsConfig

      client = Redis.from_url(
          "redis://localhost:1",
          maint_notifications_config=MaintNotificationsConfig(enabled=False),
      )
      client.connection_pool.get_available_connection()
      PY
      runHook postInstallCheck
    '';
  }
)
