# 使用轻量级的 Alpine 镜像
FROM alpine:latest

# 安装必要的运行时依赖
RUN apk --no-cache add ca-certificates tzdata curl wget tar

# 设置工作目录
WORKDIR /opt/openlist

# 在构建时动态下载最新 openlist 二进制（推荐使用 musl 版本，兼容性好）
RUN echo "Downloading latest OpenList binary..." && \
    # 获取最新下载链接
    LATEST_URL=$(curl -s https://api.github.com/repos/OpenListTeam/OpenList/releases/latest | \
                 grep "browser_download_url.*linux-musl-amd64-lite.tar.gz" | \
                 cut -d '"' -f 4) && \
    wget -q "$LATEST_URL" -O openlist.tar.gz && \
    tar -xzf openlist.tar.gz && \
    # 确保二进制名为 openlist（兼容不同打包结构）
    if [ -f openlist-linux-musl-amd64-lite ]; then \
        mv openlist-linux-musl-amd64-lite openlist; \
    fi && \
    chmod +x openlist && \
    rm openlist.tar.gz

# 暴露端口（openlist 默认端口）
EXPOSE 5244

# 启动命令
ENTRYPOINT ["./openlist"]
CMD ["server", "--no-prefix"]
