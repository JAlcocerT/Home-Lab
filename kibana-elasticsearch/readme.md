

```sh
curl -X GET "http://localhost:9200/"
# curl -X GET "http://192.168.3.200:9200/"
curl -X GET "http://192.168.3.200:9200/_cat/indices?v"

# #curl -X GET "http://192.168.3.200:9200/your_index_name/_doc/"
# curl -X GET "http://192.168.3.200:9200/sensor_data/_doc/"


# curl -X GET "http://localhost:9200/sensor_data/_mapping?pretty"
# curl -X GET "http://192.168.3.200:9200/sensor_data/_mapping?pretty"


# curl -X GET "http://192.168.3.200:9200/sensor_data/_search?pretty" -H "Content-Type: application/json" -d '{
#   "size": 1,
#   "sort": [
#     {
#       "_doc": "desc"
#     }
#   ]
# }'
```