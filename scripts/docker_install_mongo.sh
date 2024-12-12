version: '3.3'
services:
    mongo4:
        container_name: mongo4.0
        ports:
            - '47017:27017'
        environment:
            - MONGO_INITDB_ROOT_USERNAME=admin
            - MONGO_INITDB_ROOT_PASSWORD=admin123456
        volumes:
            - '/data/docker/mongo/3.2/data:/data/db'
        command: [--auth]
        image: mongo:3.2
    mongo3.2:
        container_name: mongo3.2
        ports:
            - '37017:27017'
        environment:
            - MONGO_INITDB_ROOT_USERNAME=admin
            - MONGO_INITDB_ROOT_PASSWORD=admin123456
        volumes:
            - '/data/docker/mongo/4/data:/data/db'
        command: [--auth]
        image: mongo:4