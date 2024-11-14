#!/bin/bash

TFSTATE=`cat ./terraform.tfstate`
REGION=`echo $TFSTATE | jq -r '.outputs.region.value'`
WECUBE_VPC_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_vpc") | .instances | .[0].attributes.id // empty'`
WECUBE_SUBNET_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_subnet") | .instances | .[0].attributes.id // empty'`
WECUBE_SUBNET_2_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_subnet") | .instances | .[1].attributes.id // empty'`
AZ=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_subnet") | .instances | .[0].attributes.availability_zone // empty'`
AZ2=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_subnet") | .instances | .[1].attributes.availability_zone // empty'`
WECUBE_ROUTE_TABLE_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.type == "tencentcloud_route_table") | .instances | .[0].attributes.id // empty'`
WECUBE_HOST_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.name == "vm_instances") | .instances | .[0].attributes.id // empty'`
INITIAL_PASSWORD=`echo $TFSTATE | jq -r '.resources | .[] | select(.name == "vm_instances") | .instances | .[0].attributes.password // empty'`
WECUBE_HOST_2_ASSET_ID=`echo $TFSTATE | jq -r '.resources | .[] | select(.name == "vm_instances") | .instances | .[1].attributes.id // empty'`

read -d '' CONTENT_TPL <<-EOF || true
{
  "dataCenterRegionAssetId": "${REGION}",
  "dataCenterAZ1AssetId": "${AZ}",
  "dataCenterAZ2AssetId": "${AZ2}",
  "networkZoneAssetId": "${WECUBE_VPC_ASSET_ID}",
  "networkSubZone1AssetId": "${WECUBE_SUBNET_ASSET_ID}",
  "networkSubZone2AssetId": "${WECUBE_SUBNET_2_ASSET_ID}",
  "routeTableAssetId": "${WECUBE_ROUTE_TABLE_ASSET_ID}",
  "wecubeHost1AssetId": "${WECUBE_HOST_ASSET_ID}",
  "wecubeHost1Password": "${INITIAL_PASSWORD}",
  "wecubeHost2AssetId": "${WECUBE_HOST_2_ASSET_ID}",
  "wecubeHost2Password": "${INITIAL_PASSWORD}"
}
EOF
echo $CONTENT_TPL > ./wecube_import_asset.json
