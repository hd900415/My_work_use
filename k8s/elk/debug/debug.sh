# 查看索引
curl -X GET "http://192.168.1.66:31519/_cat/indices?v" -u elastic:aGlE3w56z0abFNFflIs5
# 查看集群状态
curl -X GET "http://192.168.1.66:31519/_cat/health?v" -u elastic:aGlE3w56z0abFNFflIs5
# 查看节点
curl -X GET "http://192.168.1.66:31519/_cat/nodes?v" -u elastic:aGlE3w56z0abFNFflIs5
# 查看分片
curl -X GET "http://192.168.1.66:31519/_cat/shards?v" -u elastic:aGlE3w56z0abFNFflIs5
# 删除索引
curl -X DELETE "http://192.168.1.66:31519/logstash-2020.06.30" -u elastic:aGlE3w56z0abFNFflIs5
# 查看索引模板
curl -X GET "http://192.168.1.66:31519/_template/logstash" -u elastic:aGlE3w56z0abFNFflIs5
# 重新创建索引
curl -X POST "http://192.168.1.66:31519/logstash-2020.06.30/_rollover" -u elastic:aGlE3w56z0abFNFflIs5