# 第一阶段：构建阶段
FROM postgres:14-alpine AS builder

# 安装必要的构建工具和依赖
RUN apk add --no-cache build-base postgresql-dev zlib-dev clang19 gawk llvm19-dev

# 下载并安装 pg_repack
RUN set -x && \
    wget https://github.com/reorg/pg_repack/archive/refs/tags/ver_1.5.2.zip -O /tmp/pg_repack-1.5.2.zip && \
    unzip /tmp/pg_repack-1.5.2.zip -d /tmp && \
    cd /tmp/pg_repack-ver_1.5.2 && \
    make && \
    make install

# 第二阶段：运行阶段
FROM postgres:14-alpine

# 从构建阶段复制 pg_repack 相关文件
COPY --from=builder /usr/local/bin/pg_repack /usr/local/bin/pg_repack
COPY --from=builder /usr/local/lib/postgresql/pg_repack.so /usr/local/lib/postgresql/pg_repack.so
COPY --from=builder /usr/local/share/postgresql/extension/pg_repack.control /usr/local/share/postgresql/extension/pg_repack.control
COPY --from=builder /usr/local/share/postgresql/extension/pg_repack--1.5.2.sql /usr/local/share/postgresql/extension/pg_repack--1.5.2.sql