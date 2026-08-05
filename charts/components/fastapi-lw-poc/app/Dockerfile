# Build for fastapi-lw-poc (Python 3.12 on UBI9)
# Image build uses public PyPI (like the Java Dockerfile uses Maven Central).
# Learners use pip.conf + lightwell-repo Validated index for httpx locally.
FROM registry.access.redhat.com/ubi9/python-312:1
WORKDIR /opt/app-root/src
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py ./
ENV PYTHONUNBUFFERED=1 \
    PORT=8080 \
    LIGHTWELL_STREAM=validated
EXPOSE 8080
# ubi9/python-312 default non-root user
USER 1001
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
