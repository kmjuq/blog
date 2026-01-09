default:
    just --list

# 本地预览启动
dev:
    hugo server --cleanDestinationDir -D --disableFastRender

sync-theme: st
    git submodule update --remote