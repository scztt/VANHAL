

Require("teckDelay");

(
Pdef(\notes, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, 2 + [0, 2, 3, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1], inf).durStep(24),
        3,
        Pseq([-1, -2], inf).durStep(24),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, -2], inf).durStep(48),
)));

Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, 6,
    \legato, 2,
    \trig, 0,
    
    \amp, -12.dbamp * [0, 0, 0, 0].dbamp,
    \pan, 0.5 * [-1, 1].resamp1(4),
    \ampEnv, `Env([0, 1, 0], [0.6, 0.4], -1 * [-1, 1], releaseNode:1),
    \envScale, { ~sustain },
    
    \pos, Pmod(
        {
            var lfoRate = \lfoRate.kr(1);
            lfoRate = lfoRate + [0, 1/16].resamp1(4);
            
            4.collect({
                var trig = Dust.ar(8);
                TRand.ar(0, 1, trig).lag3(0.05)
            }).linlin(
                0, 1,
                "5:18".asSecs,
                "5:21".asSecs
            ) + (
                \lfoScale.kr(1) 
                    * SinOsc.ar(lfoRate, [0, pi].resamp1(4)).range(
                        -1, 
                        1
                    )
            )
        }, 
        \lfoScale, 0.6,
        \lfoRate, 1/4
    ).expand,
    
    \posRound, 1 / 164,
    \trigRate, Pmod({
        (1) * 94 * LFDNoise3.ar(4 * [1, 1, 1, 1]).range(-2.5, 2.5).midiratio
    }).expand,
    // \trigRateV, 0.001,
    \density, 490,
    
    \grainRate, (-12 + [0, 0.04].resamp1(4)).midiratio,
    
    \filtLo, 20,
    \filtHi, Pmod({
        SinOsc.ar(1/256, 2 + [0, 0.2].resamp1(4) - (pi/2)).exprange(1000, 8000)
    }),
    \finish, {
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
    }
) <> Pdef(\notes));

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
    
    \octave, Pkey(\octave) + 1,
    
    \delay, Pmod({
        var trig = Impulse.ar(4);
        var delay = 1 / TExpRand.ar(40, 400);
        
        4.collect {
            |i|
            delay.lag(1 * [0.05, 0.34, 0.54, 0.12])
        }
    }).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 8,
    
    \density, 450,
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.05);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/8).range(-0.5, 0.0)
            ).midiratio
        }
    }).expand,
    
    \feedAmp, -28.dbamp,
    \feedDist, 74.6, 
    
    \filtLo, 20,
    \filtHi, Pexprand(20, 1900).durStep(12),
    \filtLag, 24,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.2,
    
    \inAmp, -20.dbamp,
    \amp, -2.dbamp,
    \dryAmp, -94.dbamp
) <> Pdef(\notes));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    \amp, -16.dbamp,
    \inAmp, -16.dbamp,
    \crushAmp, 0.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 10.dbamp,
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
        ~van.out = 0;
        // ~van.out = Pout(\delay, 2);
        // ~delay.in = Pin(\delay, 2);
        // ~delay.out = 0;
        // ~teckDelay.in = ~delay;
        // ~vanCompress.in = ~teckDelay;
        // ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            