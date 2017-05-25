/+ ------------------------------------------------------------ +
 + Author : aoitofu <aoitofu@dr.com>                            +
 + This is part of CAFE ( https://github.com/aoitofu/CAFE ).    +
 + ------------------------------------------------------------ +
 + Please see /LICENSE.                                         +
 + ------------------------------------------------------------ +/
module cafe.project.timeline.property.Easing;
import cafe.project.ObjectPlacingInfo;
import std.conv;

debug = 0;

/+ イージング関数の一覧 +/
enum EasingType
{
    None,
    Linear
}

/+ イージング関数のベースクラス +/
abstract class EasingFunction
{
    private:
        float       st_value;
        float       ed_value;
        FrameLength dur;

    public:
        @property start    () { return st_value; }
        @property end      () { return ed_value; }
        @property duration () { return dur;      }

        @property start ( float s ) { st_value = s; }
        @property end   ( float e ) { ed_value = e; }

        this ( float s, float e, FrameLength d )
        {
            start = s;
            end = e;
            dur = d;
        }

        @property changeInValue ()
        {
            return end - start;
        }

        @property slope ()
        {
            return changeInValue/duration.value.to!float;
        }

        float at ( FrameAt f );

        /+ EasingTypeから対応するイージング関数のインスタンスを返す +
         + EasingType.Noneに関しては例外を返します。                +/
        static EasingFunction create ( EasingType t, float s, float e, FrameLength d )
        {
            switch ( t ) {
                case EasingType.Linear: return new LinearEasing( s, e, d );
                default: throw new Exception( "No Easing Type" );
            }
        }
}

/+ イージング関数クラスの共通コンストラクタ +/
private template EasingFunctionConstructor ()
{
    public:
        this ( float s, float e, FrameLength d )
        {
            super( s, e, d );
        }
}

/+ simple linear tweening +/
class LinearEasing : EasingFunction
{
    mixin EasingFunctionConstructor;
    public:
        override float at ( FrameAt current )
        {
            auto c = current.value;
            return slope*c + start;
        }

        debug (1) unittest {
            auto hoge = new LinearEasing( 0, 75, new FrameLength(20) );
            assert( hoge.at( new FrameAt(10) ) == 37.5 );
        }
}
