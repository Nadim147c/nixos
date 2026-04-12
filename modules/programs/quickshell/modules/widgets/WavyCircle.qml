import qs.modules.common

import QtQuick

Canvas {
    id: root

    // exposed props
    property real lineWidth: 10
    property real waveHeight: 10
    property real frequency: 25
    property real startDegree: 0
    property real degree: 360
    property real speed: 1
    property bool animate: true
    property color color: Appearance.material.myPrimary

    // ensure pixel density
    renderStrategy: Canvas.Cooperative
    antialiasing: true

    onPaint: {
        let ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        const size = Math.min(width, height);
        const centerX = width / 2;
        const centerY = height / 2;

        const radius = size / 2 - root.waveHeight * 1.5;

        const phase = animate ? (Date.now() / 400) * speed : 0;

        ctx.strokeStyle = root.color;
        ctx.lineWidth = root.lineWidth;
        ctx.lineCap = "round";

        ctx.beginPath();

        const DEG_TO_RAD = Math.PI / 180;
        const startRad = root.startDegree * DEG_TO_RAD;
        const endRad = root.degree * DEG_TO_RAD;

        // Accumulate currentAngle directly to avoid multiplication
        for (let currentAngle = 0; currentAngle <= endRad; currentAngle += DEG_TO_RAD) {
            const theta = startRad + currentAngle;
            const h = root.waveHeight * Math.sin(root.frequency * theta + phase);
            const r = radius + h;

            const x = centerX + r * Math.cos(theta);
            const y = centerY + r * Math.sin(theta);

            if (currentAngle === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }

        ctx.stroke();
    }
}
