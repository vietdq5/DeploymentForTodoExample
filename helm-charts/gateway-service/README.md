# API Gateway Helm Chart

Helm chart để triển khai ứng dụng API Gateway lên Kubernetes.

## Cách triển khai lên Docker Desktop

### Yêu cầu
- Docker Desktop đã được cài đặt và bật Kubernetes
- Helm đã được cài đặt

### Các bước triển khai

1. **Build Docker image cho ứng dụng API Gateway**

```bash
docker build -t api-gateway:latest .
```

2. **Cài đặt Helm chart**

```bash
# Di chuyển đến thư mục gốc của dự án
cd d:\PetProject\VietSample\GatewayForDeployement

# Cài đặt Helm chart
helm install api-gateway ./helm-chart
```

3. **Kiểm tra trạng thái triển khai**

```bash
# Kiểm tra pod đã được tạo
kubectl get pods

# Kiểm tra service đã được tạo
kubectl get services

# Kiểm tra configmap đã được tạo
kubectl get configmaps
```

4. **Truy cập ứng dụng API Gateway**

Nếu bạn muốn truy cập API Gateway từ máy local, bạn có thể sử dụng port-forward:

```bash
kubectl port-forward service/api-gateway-api-gateway 8080:80
```

Sau đó, bạn có thể truy cập API Gateway tại địa chỉ: http://localhost:8080

5. **Gỡ cài đặt Helm chart**

```bash
helm uninstall api-gateway
```

## Tùy chỉnh cấu hình

Bạn có thể tùy chỉnh cấu hình bằng cách chỉnh sửa file `values.yaml` hoặc cung cấp file values tùy chỉnh khi cài đặt:

```bash
helm install api-gateway ./helm-chart --values custom-values.yaml
```