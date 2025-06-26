ARG BASE=openeuler/openeuler:24.03-lts
FROM ${BASE} as builder

WORKDIR /tmp

RUN echo "root:x:0:0:root:/root:/sbin/nologin" > passwd && \
    echo "nobody:x:65534:65534:nobody:/nonexistent:/sbin/nologin" >> passwd && \
    echo "hotopic:x:1001:1001:hotopic:/home/hotopic:/sbin/nologin" >> passwd

RUN echo "root:x:0:" > group && \
    echo "nobody:x:65534:" >> group && \
    echo "tty:x:5:" >> group && \
    echo "staff:x:50:" >> group && \
    echo "hotopic:x:GID:" >> group

# 设置时区环境变量
ENV TZ=Asia/Shanghai
# 创建时区软链接并写入时区名称
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

FROM openeuler/distroless-pip:23.3.1-oe2403lts

ARG TZ=Asia/Shanghai

COPY --from=builder /tmp/passwd /etc/passwd
COPY --from=builder /tmp/group /etc/group
COPY --from=builder /usr/share/zoneinfo/${TZ} /usr/share/zoneinfo/${TZ}
COPY --from=builder /etc/localtime /etc/localtime

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .
RUN chown -R hotopic:hotopic /app

USER hotopic

CMD ["python3", "-m", "hotopic.main"]
