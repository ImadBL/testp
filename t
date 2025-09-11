templateCachePath: (absPath) => {
                const relFromSrc = path.relative(SRC, absPath);     // ex: app/pages/.../x.html
                return relFromSrc.replace(/\\/g, '/').replace(/^\/+/, '');
              },
