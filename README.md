# ai_bigdata_starter

```bash
docker run -it --rm --privileged -v `pwd`:/home/guest/host -p 23:22 -p 4040:4040 -p 5601:5601 -p 8888:8888 -p 9200:9200 -p 9300:9300 Jonarod/ai_bigdata_starter
```

Comes with:
- **Spark** for parallelized computation
- **Kafka** for Publish / Subscribe messaging
- **Anaconda** for Data Science using Python (pre-installs sci-kit learn, pandas, numpy...)
- **Cassandra** for clusterized storage
- **ElasticSearch** for indexing and fast front-end API generation
- **Kibana** for ElasticSearch's exploration and visualisation
- **Jupyter notebook** as clean coding IDE using Ipython
- **Selenium + Firefox + Geckodriver** for accurate web-scraping (executes javascript using an headless browser)


