SCP_instance(){

	gcloud compute --project "caideyi" ssh --zone "asia-east1-b" "$1" -- './TendermintOnEvm_benchmark/client.sh'
	cat 123	

}

SCP_instance $1


