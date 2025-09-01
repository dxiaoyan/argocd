BRANCH=main
#DOCKER_HUP_REPO=$(BRANCH)/${APP_NAME}
DOCKER_HUP_SERVER=
DOCKER_HUP_USERNAME=
DOCKER_HUP_PASSWORD=
OLD_IMAGES ?=
SERVER_NAME = public
TAG_NAME ?=

# 批量处理镜像的目标
process-images:
	@if [ -z "$(OLD_IMAGES)" ] || [ -z "$(DOCKER_HUP_SERVER)" ] || [ -z "$(SERVER_NAME)" ] ; then \
		echo "错误：请指定必要参数，例如："; \
		echo "make process-images OLD_IMAGES='镜像1 镜像2' DOCKER_HUP_SERVER=仓库地址 SERVER_NAME=服务名"; \
		exit 1; \
	fi
	@docker login ${DOCKER_HUP_SERVER} --username ${DOCKER_HUP_USERNAME} --password ${DOCKER_HUP_PASSWORD}
	# 循环处理每个镜像
	@for old_img in $(OLD_IMAGES); do \
    		echo "开始处理镜像: $$old_img"; \
    		\
    		# 拉取原始镜像 \
    		docker pull $$old_img; \
    		\
    		# 从原始镜像中提取名称和标签（处理无标签的情况，默认latest） \
    		image_name=$$(echo "$$old_img" | cut -d':' -f1 | rev | cut -d '/' -f 1 | rev); \
    		image_tag=$$(echo "$$old_img" | cut -d':' -f2-); \
    		if [ -z "$$image_tag" ]; then image_tag="latest"; fi; \
    		\
    		# 定义新镜像标签（格式：原始名称-原始tag） \
    		new_img="$(DOCKER_HUP_SERVER)/$(SERVER_NAME):$$image_name-$$image_tag"; \
    		\
    		# 为镜像打新标签 \
    		docker tag $$old_img $$new_img; \
    		\
    		# 打印新镜像信息 \
    		echo "生成的新镜像: $$new_img"; \
    		\
    		# 推送新镜像到仓库 \
    		docker push $$new_img; \
    		\
    		echo "镜像 $$old_img 处理完成"; \
    		echo "----------------------------------------"; \
    	done
