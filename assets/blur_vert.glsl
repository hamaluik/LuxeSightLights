attribute vec3 vertexPosition;
attribute vec2 vertexTCoord;
attribute vec4 vertexColor;
attribute vec3 vertexNormal;

varying vec4 color;

uniform float kernelSize;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying vec2 blurTexCoords[25];

void main(void) {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    gl_Position.y = -gl_Position.y;
    color = vertexColor;

    blurTexCoords[ 0] = vertexTCoord + vec2(-kernelSize      , -kernelSize      );
    blurTexCoords[ 1] = vertexTCoord + vec2(-kernelSize / 2.0, -kernelSize      );
    blurTexCoords[ 2] = vertexTCoord + vec2(              0.0, -kernelSize      );
    blurTexCoords[ 3] = vertexTCoord + vec2( kernelSize      , -kernelSize      );
    blurTexCoords[ 4] = vertexTCoord + vec2( kernelSize      , -kernelSize      );
    blurTexCoords[ 5] = vertexTCoord + vec2(-kernelSize      , -kernelSize / 2.0);
    blurTexCoords[ 6] = vertexTCoord + vec2(-kernelSize / 2.0, -kernelSize / 2.0);
    blurTexCoords[ 7] = vertexTCoord + vec2(              0.0, -kernelSize / 2.0);
    blurTexCoords[ 8] = vertexTCoord + vec2( kernelSize      , -kernelSize / 2.0);
    blurTexCoords[ 9] = vertexTCoord + vec2( kernelSize      , -kernelSize / 2.0);
    blurTexCoords[10] = vertexTCoord + vec2(-kernelSize      , -             0.0);
    blurTexCoords[11] = vertexTCoord + vec2(-kernelSize / 2.0, -             0.0);
    blurTexCoords[12] = vertexTCoord + vec2(              0.0, -             0.0);
    blurTexCoords[13] = vertexTCoord + vec2( kernelSize      , -             0.0);
    blurTexCoords[14] = vertexTCoord + vec2( kernelSize      , -             0.0);
    blurTexCoords[15] = vertexTCoord + vec2(-kernelSize      ,  kernelSize / 2.0);
    blurTexCoords[16] = vertexTCoord + vec2(-kernelSize / 2.0,  kernelSize / 2.0);
    blurTexCoords[17] = vertexTCoord + vec2(              0.0,  kernelSize / 2.0);
    blurTexCoords[18] = vertexTCoord + vec2( kernelSize      ,  kernelSize / 2.0);
    blurTexCoords[19] = vertexTCoord + vec2( kernelSize      ,  kernelSize / 2.0);
    blurTexCoords[20] = vertexTCoord + vec2(-kernelSize      ,  kernelSize      );
    blurTexCoords[21] = vertexTCoord + vec2(-kernelSize / 2.0,  kernelSize      );
    blurTexCoords[22] = vertexTCoord + vec2(              0.0,  kernelSize      );
    blurTexCoords[23] = vertexTCoord + vec2( kernelSize      ,  kernelSize      );
    blurTexCoords[24] = vertexTCoord + vec2( kernelSize      ,  kernelSize      );
}