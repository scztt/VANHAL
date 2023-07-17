

Require("teckDelay");

(
Pdef(\notes, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, 2 + [0, 2, 2.01, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1], inf).durStep(24),
        3,
        Pseq([-1, -2], inf).durStep(24),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, 6], inf).durStep(48),
)));

Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, 24,
    \legato, 1,
    
    \amp, -18.dbamp * [1, 1, 1, 1],
    \pan, 0.8 * [-1, 1].resamp1(4),
    
    \pos, Pmod(
        {
            |rate=2|
            SinOsc.ar(rate + [0, 1/24].resamp1(4)).range(
                "2:08".asSecs,
                "2:14".asSecs
            )
            + 0
            + LFTri.ar(1/128).range(0, 8)
        },
        \rate, Pmod({
            LFDNoise3.ar(1/12, 1).exprange(2.75, 3.1)
        })
    ).expand,
    
    \trigRate, { ~detunedFreq.value * 4 },
    // \trigRateV, 0.001,
    \density, 30,
    
    \ampEnv, `Env([0, 1, 0], 24 * [0.4, 0.5], \sine, releaseNode:1),
    
    \trig, 0,
    
    \grainRate, [-12, -11.9].resamp1(4).midiratio,
    
    \filtLo, 20,
    \filtHi, Pmod({
        SinOsc.kr(1/256, 0 + [0, 0.2].resamp1(4) - (pi/2)).exprange(100, 5600)
            * Env.perc(4, 0.2).kr(gate:Dust.ar(0.2)).linlin(0, 1, 0, 3).midiratio
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
    
    \delay, Pmod({
        var flux = LFDNoise3.ar(1/16).exprange(
            1/32,
            2/4
        );
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/18))
        }
    }).expand,
    \delayV, Pmod({
        1 / SinOsc.ar(1/24).exprange(20, 200)
    }),
    
    // \scale, Scale.hexSus,
    \octave, 2,
    // \degree, Pseq([0, -1], inf).durStep(16) + (1 * [0, 2.024, 5.03, 0.0253]),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 8,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            0.5 * roundOff * LFDNoise3.ar(1/8).lag(1 * [0.2, 1.0, 0.4, 0.0])
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 4,
    \density, 220,
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.12);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/4).range(1, 0.0)
            ).midiratio
        }
    }).expand,
    
    \feedAmp, -34.dbamp,
    \feedDist, Pmod({
        12 + Env.perc(2, 4, curve:\sine).ar(gate:Dust.ar(0.4)).linlin(0, 1, 0, 12)
    }),
    
    \filtLo, 60,
    \filtHi, Pexprand(200, 5900).durStep(12),
    \filtLag, 24,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.6,
    
    \amp, -10.dbamp,
    \dryAmp, -0.dbamp
) <> Pdef(\notes));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    
    \inAmp, -24.dbamp,
    \amp, -12.dbamp,
    \inAmp, -6.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 0.dbamp,
    \feed, -6.dbamp,
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
        // ~delay.out = 0;
        ~teckDelay.in = ~delay;
        ~vanCompress.in = ~teckDelay;
        ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                
                                                                                                                                                    
                                                                                                                                                        
                                                                                                                                                            
                                                                                                                                                                
                                                                                                                                                                    
                                                                                                                                                                        
                                                                                                                                                                            
                                                                                                                                                                                
                                                                                                                                                                                    
                                                                                                                                                                                        
                                                                                                                                                                                            
                                                                                                                                                                                                
                                                                                                                                                                                                    
                                                                                                                                                                                                        
                                                                                                                                                                                                            
                                                                                                                                                                                                                
                                                                                                                                                                                                                    
                                                                                                                                                                                                                        
                                                                                                                                                                                                                            
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                            