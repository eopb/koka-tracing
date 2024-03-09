alias tracing = <span,error,warn,info>

effect span
    fun push( name : string ) : ()
    fun pop() : ()

effect fun error( msg : string ) : ()
effect fun warn( msg : string ) : ()
effect fun info( msg : string ) : ()

fun instrument( name: string, action : () -> <span|e> a ) : <span|e> a
    with return(x)
        pop()
        x
    push(name)
    action()

fun main() : console ()
    with console_subscriber
    start()

fun start() : tracing ()
    with instrument("start")
    warn("hi")
    with instrument("next")
    lib/info("hi")
    error("hi")
    


fun console_subscriber(action : () -> <tracing,console|e> a ) : <console|e> a
    fun log( level, stack, msg )
        val stack' = stack.foldl("", fn (a,b){ a ++ ": " ++ b })
        println(level ++ stack' ++ ": " ++ msg)
    var stack := Nil
    with handler
        fun push(name) stack := Cons(name,stack)
        fun pop()      stack := stack.tail
    with fun error(msg) log("error",stack,msg)
    with fun warn(msg)  log("warn",stack,msg)
    with fun lib/info(msg)  log("info",stack,msg)
    action()
    
    