# Docker Images

## MATIC contracts deployer image

- [Docker Hub](https://hub.docker.com/r/leovct/matic-contracts-deployer)

```bash
docker build --tag leovct/matic-contracts-deployer:node-16 --file matic-contracts-deployer.Dockerfile .
docker push leovct/matic-contracts-deployer:node-16
```

## MATIC genesis builder

- [Docker Hub](https://hub.docker.com/r/leovct/matic-genesis-builder)

```bash
docker build --tag leovct/matic-genesis-builder:node-16 --file genesis-builder.Dockerfile .
docker push leovct/matic-genesis-builder:node-16
```
