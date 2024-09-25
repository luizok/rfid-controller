resource "aws_iot_thing" "esp32" {
    name = "ESP32"
}

resource "aws_iot_certificate" "esp32_cert" {
    active = true
}

resource "aws_iot_policy_attachment" "cert_policy_attach" {
  policy = aws_iot_policy.thing.name
  target = aws_iot_certificate.esp32_cert.arn
}

resource "aws_iot_thing_principal_attachment" "esp32_cert_attach" {
  principal = aws_iot_certificate.esp32_cert.arn
  thing     = aws_iot_thing.esp32.name
}
