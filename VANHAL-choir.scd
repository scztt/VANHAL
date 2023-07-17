

Require("teckDelay");



(
Pdef(\notes, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, [3, 3, 3, 3],
    \degree, 5 + Pseq([
        [ 0, 0.01, 1.02545, 0.134],
        [ 0, 0.01, 1.02545, 0.134] - [0, 1],
        [-2, 1.00, 3.01,    6],
        [-2, 1.00, 3.01,    6] + [0, 4],
    ], inf).durStep(32).trace + [0, 1, -7, 4]
)));

Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, 16,
    \legato, 1.5,
    
    \amp, 0.dbamp * [1, 1, 1, 1],
    \pan, 0.5 * [-1, 1],
    
    \pos, Pmod(
        {
            var lfoRate = \lfoRate.kr(1);
            lfoRate = lfoRate + [0, 1/16].resamp1(4);
            
            LFTri.ar(1/64).range(
                "2:28".asSecs,
                "2:36".asSecs
            )
            + (
                \lfoScale.kr(1) * SinOsc.ar(lfoRate).range(-1, 1)
            )
        },
        \lfoRate, 0.7,
        \lfoScale, 0.2,
        
    ).expand,
    
    \posV, 1/60,
    \posRound, Pmod({ 
        1 / LFDNoise3.ar(1/48).exprange(40, 700)
    }),
    \posRoundOffset, Pmod({
        0.3 * (1/400) * SinOsc.ar(1/48, [0, pi]).range(-1, 1)
    }).expand,
    
    \trigRate, 60 * 4,
    \trigRateV, 0.05,
    
    \ampEnv, `Env([0, 1, 0], [6, 8], \sine, releaseNode:1),
    
    \trig, 0,
    
    \grainRate, { (~detunedFreq.value.cpsmidi - 42).midiratio },
    
    \filtHi, Pmod({
        SinOsc.ar(1/256, 0 + [0, 0.2].resamp1(4) - (pi/2)).exprange(100, 13000)
    }),
    
    \density, Pmod({
        TRand.ar(0, 1, Impulse.ar(0) + Dust.ar(0.16)).linexp(0, 1, 20, 60).lag3(30)
    }),
    
    \finish, {
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
    }
    
    // \dur, 1,
    // \legato, 1,
) <> Pdef(\notes) );

Pdef(\delay, Pmono(
    \grainDelay2,
    \parentType, \grainDelay2,
    
    \finish, {
        ~in = ~in.value.postln;
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
        ~grainRate = ~grainRate.value;
        ~delayRound = ~delayRound.value;
    },
    
    \delay, Pmod({
        var flux = SinOsc.ar(1/6).exprange(
            LFDNoise3.kr(1/64).exprange(1/500, 1/8),
            3/4
        );
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/8).range(0, 1/32))
        }
    }).expand,
    \delayV, 1/490,
    
    \scale, Scale.hexSus,
    \octave, 2,
    \degree, Pseq([0, -1], inf).durStep(16) + (1 * [0, 3.024, 5.03, 0.0253]),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 8,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            0.2 * roundOff * LFDNoise3.ar(1/1).lag(0.4 * [0.1, 1.0, 0.4, 0.0].scramble)
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 3,
    \trigRateV, 0.03,
    \density, 40,
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.13);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/4).range(-0.02, 0.02)
            ).midiratio
        }
    }).expand,
    
    \feedAmp, -24.dbamp,
    \feedDist, Pmod({ 
        SinOsc.kr(1/24, [0, pi].resamp1(4) - (pi/2)).lincurve(-1, 1, 0.5, 26, 8) 
    }).expand,
    \filtLo, 60,
    \filtHi, Pexprand(600, 15000).durStep(12),
    \filtLag, 24,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.2,
    
    \amp, -27.dbamp,
    \dryAmp, 10.dbamp
) <> Pdef(\notes) );

Pdef(\teckDelay, Pmono(
    \teckDelay,
    \amp, -36.dbamp,
    \inAmp, -6.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, -0.dbamp,
    \inEnv, 0
));

Pdef(\vanCompress,
    Pdef(\compressor)
).set(
    \c, ~vanCompress = ~vanCompress ?? {
        ControlValueEnvir(BusControlValue)
});

Pdef(\player, Pio(Ppar(
    Pio.make({
        // ~van.out = 0;
        ~van.out = Pout(\delay, 2);
        ~delay.in = Pin(\delay, 2);
        ~teckDelay.in = ~delay;
        ~vanCompress.in = ~teckDelay;
        ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            