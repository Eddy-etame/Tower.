-- Single source of truth for build identity, printed at boot by both server and client.
-- stage stays "scaffold" until the first approved experience design (T1-T4) reaches implementation.
return {
	major = 0,
	minor = 1,
	patch = 0,
	stage = "scaffold",
}
