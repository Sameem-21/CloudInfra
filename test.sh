echo "INSTANCE_ID<<EOF"
          terraform output -raw app_instance_id
          echo "EOF"

          echo "PUBLIC_IP<<EOF"
          terraform output -raw app_instance_public_ip
          echo "EOF"

          echo "AZ<<EOF"
          terraform output -raw app_instance_az
          echo "EOF"
