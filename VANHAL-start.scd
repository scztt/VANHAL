

Require("teckDelay");

(
~teck_c = ~teck_c ?? { ControlValueEnvir(BusControlValue) };
~teck_c.use {
    ~pos_lfoRate.spec = ControlSpec(0.02, 18,	warp:3, default: 0);
    ~pos_lfoScale.spec = ControlSpec(0, 4,		warp:4, default: 0);
    
    ~filt_lo.spec = ControlSpec(20, 18000,		warp:\exp, default: 20);
    ~filt_hi.spec = ControlSpec(20, 18000,		warp:\exp, default: 18000);
    
    ~delay_amp.spec = ControlSpec(-90, 0,		default: -90);
};

~teck_c.setGroupProperties();

ElectraFactory.load(~teck_c);
)

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
    
    \dur, 24,
    \legato, 1.5,
    \trig, 0,
    
    \amp, -16.dbamp * [0, 6, 6, 0].dbamp,
    \pan, 0.9 * [-1, 1],
    
    \pos, Pmod(
        {
            var lfoRate = \lfoRate.kr(1);
            lfoRate = lfoRate + [0, 1/16].resamp1(4);
            
            Env(
                [0, 117, 125, 117, 125, 117, 125],
                [117, 30, 40, 45, 60, 65],
                [0, \sine, \sine, \sine, \sine]
            ).ar(gate:1)
            + (
                \lfoScale.kr(1) 
                    * SinOsc.ar(lfoRate, [0, 1.5*pi].resamp1(4)).range(
                        -1, 
                        1
                    )
            )
        }, 
        \lfoScale, ~teck_c[\pos_lfoScale].asStream(0.01),
        \lfoRate, ~teck_c[\pos_lfoRate].asStream(1/8)
    ).expand,
    
    // \posV, 0.0002,
    
    \trigRate, { ~detunedFreq.value * 1 },
    \trigRateV, 0.5,
    \density, 8,
    
    \ampEnv, `Env([0, 1, 0], [6, 8], \sine, releaseNode:1),
    
    \grainRate, Pmod({
        4.collect {
            1 
                * LFDNoise3.ar(1/26).range(-0.2, 0.2).midiratio
                // * SinOsc.ar(22).range(-0.1, 0.1).midiratio
        }
    }),
    
    \filtLo, ~teck_c[\filt_lo].asStream(20),
    \filtHi, ~teck_c[\filt_hi].asStream(16000),
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
        var flux = LFDNoise3.ar(1/4).exprange(
            1/12,
            1/2
        );
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/32))
        }
    }).expand,
    \delayV, Pmod({
        1 / SinOsc.ar(1/4).exprange(4, 20)
    }),
    \delayRound, 1/45,
    \delayRoundOffset, Pmod({
        0.01 * SinOsc.ar(44.4).range(-1, 1)
    }),
    
    \trig, 0,
    
    \trigRate, 40 * 1,
    
    \density, 72,
    
    \grainRate, Pmod({
        DC.ar(-0.04.midiratio)
    }).expand,
    
    \feedAmp, -16.dbamp,
    
    \feedDist, 4.0,
    \filtLo, 10,
    \filtHi, 420,
    \prePost, 1,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.1,
    
    \amp, -2.dbamp,
    \dryAmp, -90.dbamp,
) <> Pdef(\notes));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    \amp, -16.dbamp,
    \inAmp, -0.dbamp,
    \crushAmp, 0.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, -90.dbamp,
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
        ~delay.out = 0;
        // ~teckDelay.in = ~delay;
        // ~vanCompress.in = ~teckDelay;
        // ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                