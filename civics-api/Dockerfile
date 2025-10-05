FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev libssl-dev ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN R -q -e "install.packages(c('plumber','dplyr','tidyr','jsonlite','rlang'), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY . .   # copies files from civics-api/

ENV PORT=8000
ENV CSV_PATH=/app/CR_Data_Names.csv

EXPOSE 8000
CMD ["Rscript", "entrypoint.R"]
