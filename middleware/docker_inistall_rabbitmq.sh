docker run -d --name rabbitmq \
--restart always \
-e RABBITMQ_DEFAULT_USER=admin \
-e RABBITMQ_DEFAULT_PASS='53$D#Hasdjrt' \
-p 15672:15672 \
-p 5672:5672 \
-p 25672:25672 \
-p 61613:61613 \
-p 1883:1883 \
rabbitmq:management