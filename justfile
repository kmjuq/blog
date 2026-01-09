default:
    just --list

alias st := sync-theme

# 本地预览启动
dev:
    hugo server --cleanDestinationDir -D --disableFastRender

sync-theme:
    git submodule update --remote