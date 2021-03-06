/+ ------------------------------------------------------------ +
 + Author : aoitofu <aoitofu@dr.com>                            +
 + This is part of CAFE ( https://github.com/aoitofu/CAFE ).    +
 + ------------------------------------------------------------ +
 + Please see /LICENSE.                                         +
 + ------------------------------------------------------------ +/
module cafe.gui.controls.timeline.SnapCorrector;
import cafe.config,
       cafe.gui.controls.timeline.Cache,
       cafe.project.timeline.Timeline,
       cafe.project.timeline.PlaceableObject,
       cafe.project.timeline.property.Property,
       cafe.project.timeline.property.PropertyList;
import std.algorithm,
       std.conv,
       std.math;

/+ インスタンスを作らずに補正 +/
@property correct ( Cache c, float f )
{
    return (new SnapCorrector( c )).correct( f );
}

/+ タイムラインのスナップポイントを算出＆位置補正 +/
class SnapCorrector
{
    static @property MaxCorrectDistancePx ()
    {
        return config( "behaviour/timeline/CorrectableDistancePx" ).uintegerDef( 10 ).to!int;
    }

    private:
        Cache  cache;
        uint[] snap_frames;

        void fromProperty ( Property p, uint st )
        {
            if ( cache.operation.operatingProperty is p ) return;
            p.middlePoints.each
                !( x => snap_frames ~= x.frame.start.value + st );
        }

        void fromPropertyList ( PropertyList p, uint st )
        {
            p.properties.values.each!( x => fromProperty( x, st ) );
        }

        void fromObject ( PlaceableObject o )
        {
            if ( cache.operation.operatingObject is o ) return;
            auto st = o.place.frame.start.value;
            fromPropertyList( o.propertyList, st );
            o.effectList.effects.each
                !( x => fromPropertyList( x.propertyList, st ) );
            snap_frames ~= o.place.frame.end.value;
        }

    public:
        this ( Cache c )
        {
            cache = c;
            cache.timeline.objects.each!( x => fromObject(x) );
        }

        auto correct ( float f )
        {
            if ( f == 0 ) return 0;

            auto ppf = cache.pxPerFrame;

            auto cur_index = 0;
            auto min_score = uint.max.to!float;

            foreach ( i,v; snap_frames ) {
                auto score = ( v - f ).abs;
                if ( score <= min_score ) {
                    min_score = score;
                    cur_index = i.to!int;
                }
            }
            auto dist_px = min_score*ppf;
            if ( dist_px < MaxCorrectDistancePx )
                return snap_frames[cur_index];
            else return max( f, 0 ).round.to!uint;
        }
}
