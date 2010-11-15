# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron

# current nasal version doesn't accept :
# - too many operations on 1 line.
# - variable with hyphen (?).



# ==============
# Initialization
# ==============

BoeingMain = {};

BoeingMain.new = func {
   var obj = { parents : [BoeingMain]
         };

   obj.init();

   return obj;
}

BoeingMain.putinrelation = func {
   autopilotsystem.set_relation( autothrottlesystem );
   warningsystem.set_relation( doorsystem );
}

# 1 s cron
BoeingMain.sec1cron = func {
   autopilotsystem.schedule();
   flightsystem.schedule();
   fuelsystem.schedule();
   warningsystem.schedule();
   daytimeinstrument.schedule();

   # schedule the next call
   settimer(func{ me.sec1cron(); },autopilotsystem.AUTOPILOTSEC);
}

# 2 s cron
BoeingMain.sec2cron = func {
   autothrottlesystem.schedule();
   gearsystem.schedule();

   # schedule the next call
   settimer(func{ me.sec2cron(); },autothrottlesystem.AUTOTHROTTLESEC);
}

# 3 s cron
BoeingMain.sec3cron = func {
   tcasinstrument.schedule();

   # schedule the next call
   settimer(func{ me.sec3cron(); },tcasinstrument.TCASSEC);
}

# 5 s cron
BoeingMain.sec5cron = func {
   tractorexternal.schedule();

   # schedule the next call
   settimer(func{ me.sec5cron(); },tractorexternal.TRACTORSEC);
}

# 60 s cron
BoeingMain.sec60cron = func {
   engineercrew.veryslowschedule();

   # schedule the next call
   settimer(func { me.sec60cron(); },60);
}

BoeingMain.savedata = func {
   aircraft.data.add("/controls/autoflight/fg-waypoint");
   aircraft.data.add("/controls/seat/recover");
   aircraft.data.add("/systems/fuel/presets");
   aircraft.data.add("/systems/seat/position/cargo-aft/x-m");
   aircraft.data.add("/systems/seat/position/cargo-aft/y-m");
   aircraft.data.add("/systems/seat/position/cargo-aft/z-m");
   aircraft.data.add("/systems/seat/position/cargo-forward/x-m");
   aircraft.data.add("/systems/seat/position/cargo-forward/y-m");
   aircraft.data.add("/systems/seat/position/cargo-forward/z-m");
   aircraft.data.add("/systems/seat/position/gear-well/x-m");
   aircraft.data.add("/systems/seat/position/gear-well/y-m");
   aircraft.data.add("/systems/seat/position/gear-well/z-m");
   aircraft.data.add("/systems/seat/position/observer/x-m");
   aircraft.data.add("/systems/seat/position/observer/y-m");
   aircraft.data.add("/systems/seat/position/observer/z-m");
}

# global variables in Boeing747 namespace, for call by XML
BoeingMain.instantiate = func {
   globals.Boeing747.constant = Constant.new();
   globals.Boeing747.constantaero = ConstantAero.new();

   globals.Boeing747.autopilotsystem = Autopilot.new();
   globals.Boeing747.autothrottlesystem = Autothrottle.new();
   globals.Boeing747.fuelsystem = Fuel.new();
   globals.Boeing747.flightsystem = Flight.new();
   globals.Boeing747.gearsystem = Gear.new();
   globals.Boeing747.warningsystem = Warning.new();

   globals.Boeing747.tcasinstrument = Traffic.new();
   globals.Boeing747.daytimeinstrument = DayTime.new();

   globals.Boeing747.doorsystem = Doors.new();
   globals.Boeing747.seatsystem = Seats.new();

   globals.Boeing747.menuscreen = Menu.new();

   globals.Boeing747.engineercrew = Virtualengineer.new();

   globals.Boeing747.tractorexternal = Tractor.new();
}

# initialization
BoeingMain.init = func {
   # 1 path per name + 1 path for index
   aircraft.livery.init( "Aircraft/747-200/Models/Liveries",
                         "sim/model/livery/name",
                         "sim/model/liveryseat/name",
                         "sim/model/liveryseat/index" );

   me.instantiate();
   me.putinrelation();

   # schedule the 1st call
   settimer(func { me.sec1cron(); },0);
   settimer(func { me.sec2cron(); },0);
   settimer(func { me.sec3cron(); },0);
   settimer(func { me.sec5cron(); },0);
   settimer(func { me.sec60cron(); },0);

   # saved on exit, restored at launch
   me.savedata();
}


L747200 = setlistener("/sim/signals/fdm-initialized", func { thejumbojet = BoeingMain.new(); removelistener(L747200); });
