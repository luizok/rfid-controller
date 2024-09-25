output "AmazonRootCA1" {
    value = data.http.AmazonRootCA1.body
}

output "esp32_cert" {
    value = aws_iot_certificate.esp32_cert.certificate_pem
    sensitive = true
}

output "esp32_cert_private_key" {
    value = aws_iot_certificate.esp32_cert.private_key
    sensitive = true
}

output "mqtt_endpoint" {
    value = data.aws_iot_endpoint.thing_ats_mqtt.endpoint_address
}
