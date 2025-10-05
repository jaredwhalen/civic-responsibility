FROM rocker/r2u:jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
    r-cran-plumber r-cran-dplyr r-cran-tidyr r-cran-jsonlite r-cran-rlang \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY api.R service.R entrypoint.R CR_Data_Names.csv ./

ENV PORT=8000
ENV CSV_PATH=/app/CR_Data_Names.csv

EXPOSE 8000
CMD ["Rscript", "entrypoint.R"]
