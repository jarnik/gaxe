package gaxe;

class Signaler<T>
{

	private var listeners:Array<T -> Void>;
	private var listenersVoid:Array<Void -> Void>;
	private var bubblingTargets:Array<Signaler<T>>;

	public function new() 
	{		
		this.listeners = [];
		this.listenersVoid = [];
		this.bubblingTargets = [];
	}

	public function bind( listener: T -> Void ):Void
	{
		this.listeners.push( listener );
	}

	public function bindVoid( listener: Void -> Void ):Void
	{
		this.listenersVoid.push( listener );
	}

	public function addBubblingTarget( target: Signaler<T> )
	{
		this.bubblingTargets.push( target );
	}

	public function dispatch(value:T = null):Void
	{
		for ( listener in listeners )
		{
			listener( value );
		}
		for ( listener in listenersVoid )
		{
			listener();
		}
		for ( listener in bubblingTargets )
		{
			listener.dispatch( value );
		}
	}	

}