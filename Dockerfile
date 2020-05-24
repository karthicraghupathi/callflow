FROM ubuntu:20.04 AS builder
LABEL maintainer="karthicr@gmail.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Etc/UTC
ENV CALLFLOWVERSION=20200523
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    ca-certificates \
    cmake \
    make \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget -O callflow-${CALLFLOWVERSION}.tar.bz2 https://github.com/karthicraghupathi/callflow/releases/download/v${CALLFLOWVERSION}/callflow-${CALLFLOWVERSION}.tar.bz2 \
    && tar xf callflow-${CALLFLOWVERSION}.tar.bz2 \
    && cd callflow-${CALLFLOWVERSION} \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \
    && rm -rf callflow-${CALLFLOWVERSION}

FROM ubuntu:20.04
LABEL maintainer="karthicr@gmail.com"
RUN apt-get update \
    && apt-get -y install --no-install-recommends software-properties-common \
    && add-apt-repository -u -y ppa:inkscape.dev/stable \
    && apt-get -y install --no-install-recommends gawk inkscape tshark \
    && apt-get -y purge --auto-remove software-properties-common \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/callflow /usr/local/bin/
COPY --from=builder /usr/local/share/doc/callflow /usr/local/share/doc/callflow
COPY --from=builder /usr/local/callflow/ /usr/local/callflow/
COPY --from=builder /usr/local/share/man/man1/callflow.1 /usr/local/share/man/man1/
COPY --from=builder /usr/local/etc/callflow/callflow.conf /usr/local/etc/callflow/
