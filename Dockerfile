FROM python:3.10-slim

RUN echo '#!/bin/bash\napt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/' > /usr/bin/apt-vacuum && chmod +x /usr/bin/apt-vacuum

RUN apt update \
 && apt install -y gawk wget unzip \
 && apt-vacuum

RUN pip install --no-cache-dir dask pandas

WORKDIR /root
ENV DATA_SAMPLE_ZIP='data_sample.log.zip'
RUN wget -O "${DATA_SAMPLE_ZIP}" "https://drive.google.com/u/0/uc?id=1eTYkofKPTanLa76TEoyz7PynNvp_Vt_H&export=download" \
 && unzip "${DATA_SAMPLE_ZIP}" \
 && rm "${DATA_SAMPLE_ZIP}"

ENTRYPOINT [ "/bin/bash" ]
