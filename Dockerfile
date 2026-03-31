# OCI bundle of tracked cursor rules + generated persona markdown for Kubernetes
# (employee-factory initContainer copies `.cursor/personas/alex-personality.md`).
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
WORKDIR /rules
COPY . .
