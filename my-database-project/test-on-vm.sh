#!/bin/bash

# Скрипт для тестування лабораторної роботи 2 на Azure VM
# Використання: ./test-on-vm.sh [VM_IP] [SSH_USER]

set -e

VM_IP=${1:-"your-vm-ip"}
SSH_USER=${2:-"student"}

echo "🧪 Testing Lab 2 on Azure VM"
echo "VM IP: $VM_IP"
echo "SSH User: $SSH_USER"
echo ""

# Функція для виконання команд на VM
run_on_vm() {
    ssh -i "/Users/stanislavkovalcuk/Desktop/db-lab1-vm_key.pem" -o StrictHostKeyChecking=no $SSH_USER@$VM_IP "$1"
}

# Функція для копіювання файлів на VM
copy_to_vm() {
    scp -i "/Users/stanislavkovalcuk/Desktop/db-lab1-vm_key.pem" -o StrictHostKeyChecking=no "$1" $SSH_USER@$VM_IP:"$2"
}

echo "🔍 Checking VM connection..."
if ! run_on_vm "echo 'VM connection successful'"; then
    echo "❌ Cannot connect to VM. Please check:"
    echo "1. VM is running"
    echo "2. SSH key is configured"
    echo "3. IP address is correct"
    exit 1
fi
echo "✅ VM connection successful"

echo ""
echo "📊 Checking application status..."
run_on_vm "sudo systemctl status my-database-project || echo 'Service not found'"

echo ""
echo "🌐 Testing API endpoint..."
if run_on_vm "curl -s -u user:password http://localhost:8080/api/authors"; then
    echo "✅ API is working"
else
    echo "❌ API is not responding"
fi

echo ""
echo "📈 Running load test..."
copy_to_vm "load-test.py" "/tmp/load-test.py"
copy_to_vm "requirements.txt" "/tmp/requirements.txt"

run_on_vm "cd /tmp && python3 -m pip install aiohttp --quiet"
run_on_vm "cd /tmp && python3 load-test.py --url http://localhost:8080 --users 5 --duration 30"

echo ""
echo "🐳 Checking Docker containers..."
run_on_vm "docker ps || echo 'Docker not available'"

echo ""
echo "📋 Checking logs..."
run_on_vm "sudo journalctl -u my-database-project --no-pager -n 20 || echo 'No service logs'"

echo ""
echo "✅ Testing completed!"
echo ""
echo "🌐 Your application should be available at:"
echo "   http://$VM_IP:8080"
echo ""
echo "📚 API endpoints:"
echo "   GET  http://$VM_IP:8080/api/authors"
echo "   GET  http://$VM_IP:8080/api/books"
echo "   GET  http://$VM_IP:8080/swagger-ui.html"
echo ""
echo "🔐 Credentials: user:password"
