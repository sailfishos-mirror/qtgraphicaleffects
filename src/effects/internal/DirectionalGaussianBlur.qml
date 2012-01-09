/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Graphical Effects module.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0

Item {
    id: rootItem
    property variant source
    property real deviation: (radius + 1) / 3.3333
    property real radius: 0.0
    property int maximumRadius: 0
    property real horizontalStep: 0.0
    property real verticalStep: 0.0
    property bool transparentBorder: false
    property bool cached: false

    SourceProxy {
        id: sourceProxy
        input: rootItem.source
    }

    ShaderEffectSource {
        id: cacheItem
        anchors.fill: rootItem
        visible: rootItem.cached
        smooth: true
        sourceItem: shaderItem
        live: true
        hideSource: visible
    }

    ShaderEffect {
        id: shaderItem
        property variant source: sourceProxy.output
        property real deviation: rootItem.deviation
        property real radius: rootItem.radius
        property int maxRadius: rootItem.maximumRadius
        property bool transparentBorder: rootItem.transparentBorder
        property real deltaX: rootItem.horizontalStep
        property real deltaY: rootItem.verticalStep
        property real gaussianSum: 0.0
        property real startIndex: 0.0
        property real deltaFactor: (2 * radius - 1) / (maxRadius * 2 - 1)
        property real expandX: transparentBorder && deltaX > 0 ? maxRadius / width : 0.0
        property real expandY: transparentBorder && deltaY > 0 ? maxRadius / height : 0.0
        property real pixelX: 1.0 / (width / (1.0 - 2 * expandX))
        property real pixelY: 1.0 / (height / (1.0 - 2 * expandY))
        property variant gwts: []
        property variant delta: Qt.vector3d(deltaX * deltaFactor, deltaY * deltaFactor, startIndex);
        property variant factor_0_2: Qt.vector3d(gwts[0], gwts[1], gwts[2]);
        property variant factor_3_5: Qt.vector3d(gwts[3], gwts[4], gwts[5]);
        property variant factor_6_8: Qt.vector3d(gwts[6], gwts[7], gwts[8]);
        property variant factor_9_11: Qt.vector3d(gwts[9], gwts[10], gwts[11]);
        property variant factor_12_14: Qt.vector3d(gwts[12], gwts[13], gwts[14]);
        property variant factor_15_17: Qt.vector3d(gwts[15], gwts[16], gwts[17]);
        property variant factor_18_20: Qt.vector3d(gwts[18], gwts[19], gwts[20]);
        property variant factor_21_23: Qt.vector3d(gwts[21], gwts[22], gwts[23]);
        property variant factor_24_26: Qt.vector3d(gwts[24], gwts[25], gwts[26]);
        property variant factor_27_29: Qt.vector3d(gwts[27], gwts[28], gwts[29]);
        property variant factor_30_32: Qt.vector3d(gwts[30], gwts[31], gwts[32]);

        anchors.fill: rootItem

        function gausFunc(x){
            //Gaussian function = h(x):=(1/sqrt(2*3.14159*(D^2))) * %e^(-(x^2)/(2*(D^2)));
            return (1.0 / Math.sqrt(2 * Math.PI * (Math.pow(shaderItem.deviation, 2)))) * Math.pow(Math.E, -((Math.pow(x, 2)) / (2 * (Math.pow(shaderItem.deviation, 2)))));
        }

        function updateGaussianWeights() {
            gaussianSum = 0.0;
            startIndex = -maxRadius + 0.5

            var n = new Array(32);
            for (var j = 0; j < 32; j++)
                n[j] = 0;

            var max = maxRadius * 2
            var delta = (2 * radius - 1) / (max - 1);
            for (var i = 0; i < max; i++) {
                n[i] = gausFunc(-radius + 0.5 + i * delta);
                gaussianSum += n[i];
            }

            gwts = n;
        }

        function buildFragmentShader() {
        var linearSteps = ""

        if (transparentBorder)
            linearSteps = "* linearstep(0.0, pixelX, texCoord.s) * linearstep(1.0, stepX, texCoord.s) * linearstep(0.0, pixelY, texCoord.t) * linearstep(1.0, stepY, texCoord.t)"

        var shaderSteps = [
            "gl_FragColor += texture2D(source, texCoord) * factor_0_2.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_0_2.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_0_2.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_3_5.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_3_5.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_3_5.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_6_8.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_6_8.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_6_8.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_9_11.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_9_11.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_9_11.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_12_14.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_12_14.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_12_14.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_15_17.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_15_17.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_15_17.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_18_20.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_18_20.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_18_20.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_21_23.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_21_23.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_21_23.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_24_26.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_24_26.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_24_26.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_27_29.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_27_29.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_27_29.z" + linearSteps + "; texCoord += shift;",

            "gl_FragColor += texture2D(source, texCoord) * factor_30_32.x" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_30_32.y" + linearSteps + "; texCoord += shift;",
            "gl_FragColor += texture2D(source, texCoord) * factor_30_32.z" + linearSteps + "; texCoord += shift;"
        ]

            var shader = fragmentShaderBegin
            var samples = maxRadius * 2
            if (samples > 32) {
                console.log("DirectionalGaussianBlur.qml WARNING: Maximum of blur radius (16) exceeded!")
                samples = 32
            }

            for (var i = 0; i < samples; i++) {
                shader += shaderSteps[i]
            }

            shader += fragmentShaderEnd
            fragmentShader = shader
        }

        onDeviationChanged: updateGaussianWeights()

        onRadiusChanged: updateGaussianWeights()

        onTransparentBorderChanged: {
            buildFragmentShader()
            updateGaussianWeights()
        }

        onMaxRadiusChanged: {
            buildFragmentShader()
            updateGaussianWeights()
        }

        Component.onCompleted: {
            buildFragmentShader()
            updateGaussianWeights()
        }

        property string fragmentShaderBegin: "
            varying mediump vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform sampler2D source;
            uniform highp vec3 delta;
            uniform highp vec3 factor_0_2;
            uniform highp vec3 factor_3_5;
            uniform highp vec3 factor_6_8;
            uniform highp vec3 factor_9_11;
            uniform highp vec3 factor_12_14;
            uniform highp vec3 factor_15_17;
            uniform highp vec3 factor_18_20;
            uniform highp vec3 factor_21_23;
            uniform highp vec3 factor_24_26;
            uniform highp vec3 factor_27_29;
            uniform highp vec3 factor_30_32;
            uniform highp float gaussianSum;
            uniform highp float expandX;
            uniform highp float expandY;
            uniform highp float pixelX;
            uniform highp float pixelY;

            highp float linearstep(highp float e0, highp float e1, highp float x) {
                return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
            }

            highp float dlinearstep(highp float e0, highp float d, highp float x) {
                return clamp((x - e0) * d, 0.0, 1.0);
            }

            void main() {
                highp vec2 shift = vec2(delta.x, delta.y);
                highp float index = delta.z;
                mediump vec2 texCoord = qt_TexCoord0;
                highp float stepX = 1.0 - pixelX;
                highp float stepY = 1.0 - pixelY;
                texCoord.s = (texCoord.s - expandX) / (1.0 - 2.0 * expandX);
                texCoord.t = (texCoord.t - expandY) / (1.0 - 2.0 * expandY);
                texCoord +=  (shift * index);

                gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        "

        property string fragmentShaderEnd: "
                if (gaussianSum > 0.0)
                    gl_FragColor /= gaussianSum;
                else
                    gl_FragColor = texture2D(source, qt_TexCoord0);

                gl_FragColor *= qt_Opacity;
            }
        "
     }
}