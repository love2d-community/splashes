

#ifdef PIXEL

uniform float t;

const float pink_r = 231.0 / 255.0;
const float pink_g = 74.0 / 255.0;
const float pink_b = 153.0 / 255.0;

const float blue_r = 39.0 / 255.0;
const float blue_g = 170.0 / 255.0;
const float blue_b = 224.0 / 255.0;

const float black_r = 0.1;
const float black_g = 0.1;
const float black_b = 0.15;

const float PI = 3.141593;
const float ANIM_DURATION = 1.1;
const float DIAMETER = 0.3; // diameter of the circle relative to the width or height of the screen (whichever is smaller)


float f(float x) { // sine from 0 to 1
	return 0.5 * sin(PI * (x - 0.5)) + 0.5;
}

float g(float x) { // spring from 0 to 1
	return 1.0 - pow(2, -10 * pow(x, 0.65)) * cos(4.5 * PI * x);
}

float interpolateRotation(float x) { // from 0 to 1, a curve that accelerates towards 1 like a sine, but then halfway reaches the point and wobbles like a spring until it settles
	return g(x * x * f(x));
}

float interpolateRadius(float x) {
	return -pow(x - 1.0, 3.0); // from 1 to 0
}


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {

	float x = min(1.0, t / ANIM_DURATION);

	// rotation vars
	float stripeStartAngle = atan(love_ScreenSize.x / love_ScreenSize.y);
	float stripeEndAngle = 1.25 * PI;
	float stripeCurAngle = stripeStartAngle + (stripeEndAngle - stripeStartAngle) * interpolateRotation(x);

	// radius vars
	float minLength = min(love_ScreenSize.x, love_ScreenSize.y);
	float circleEndRadius = minLength * DIAMETER * 0.5;
	float circleMaxRadius = sqrt(love_ScreenSize.x * love_ScreenSize.x + love_ScreenSize.y * love_ScreenSize.y) * 0.5;
	float curRadius = circleEndRadius + (circleMaxRadius - circleEndRadius) * interpolateRadius(x);

	
	
	float dx = screen_coords.x - love_ScreenSize.x / 2.0;
	float dy = screen_coords.y - love_ScreenSize.y / 2.0;
	float angleWithCenter = atan(dy, dx);
	angleWithCenter = (angleWithCenter + PI); // guaranteed to be a value between 0 and 2*pi evenly distributed
	float disToCenter = sqrt(dx * dx + dy * dy);

	if (disToCenter < curRadius) { // check if you're inside the circle
		
		if (mod(angleWithCenter + stripeCurAngle, 2.0 * PI) < PI) { // check if you're going to be blue or pink based on the pixel's angle with the center and the interpolated angle
			return vec4(blue_r, blue_g, blue_b, 1.0);

		} else {
			return vec4(pink_r, pink_g, pink_b, 1.0);
		}
		
	}



	return vec4(black_r, black_g, black_b, 1.0);
}



#endif
