.PHONY: init plan apply destroy clean

# 初期化
init:
	cd terraform && terraform init

# 変更内容の確認
plan:
	cd terraform && terraform plan

# デプロイ (構築)
apply:
	cd terraform && terraform apply -auto-approve

# お片付け (削除)
destroy:
	cd terraform && terraform destroy -auto-approve

# エイリアス (cleanでも削除できるようにする)
clean: destroy
