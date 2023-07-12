
## TODO: config ad comment the srtyle
formatstyle=DOM.style("""
    .hoverable:not(.border){
        transition: all 0.1s ease;
    }
    .hoverable:not(.border):hover, .stay:not(.border){
        transform: scale(1.1);
    }

    .hoverable.border{
        transition: all 0.1s ease;
        border: 2px solid transparent;

    }
    .hoverable.border:hover, .stay.border{
        border: 2px solid black;
    }

    .hstack{
        display:flex;
        flex-direction: row;
    }

    .vstack{
        display: flex;
        flex-direction: column;
    }

    .align-center{
        align-items: center;
    }

    .justify-center{
        justify-content: center;
    }

    .zstack{
        display:flex;
        flex-direction: row;
    }

    .zstack, .zstack > *{
        transition: all 0.3s ease;
    }

    .zstack:not(.static, .opacity) .active{
        transition: all 0.3s ease;
        width: 100%;
        overflow: hidden;

    }

    .zstack:not(.static, .opacity) > :not(.active){
        transition: all 0.3s ease;
        width: 0%;
        overflow: hidden;
    }

    .zstack.static .active{
        overflow: hidden;

    }

    .zstack.static > :not(.active){
        width: 0px;
        overflow: hidden;
    }

    .zstack.opacity .active{
        transition: all 0.1s ease;
        opacity: 1;

    }

    .zstack.opacity > :not(.active){
        transition: all 0.1s ease;
        opacity: 0;
    }

    .menufigs {
        display:flex;
        flex-direction: row;
        justify-content: space-around;
        background-color: rgb(242, 242, 247);
        padding-top: 20px;
    }

    .upper{
        text-transform: uppercase;
    }


    """)

###################### 1. Helper functions for UX ######################
#   Functions that add css classes to DOM.div elements in order to 
#   createa a nice UX experience and also cleaner code

# Scene content to md
markdowned(figure) = md"""$(figure.scene)"""

# Equivalend of DOM.div
wrap(content...; class="", style="", md=false) = DOM.div(JSServe.MarkdownCSS,
                                            JSServe.Styling,
                                            md ? [markdowned(i) for i in content] : content,
                                            style=style, class=class)

# DOM.div + add hoverable class
hoverable(item...; class="", style="", md=false) = wrap(item; class="hoverable "*class, style=style, md=md)

# hoverable + remain active on observable==1
function hoverable!(item...; observable=nothing, session=nothing, class="", style="", md=false)
    return classstack!(hoverable(item; class=class, style=style, md=md);
                    observable=observable, session=session, height=2,
                    toggleclasses=["stay", "_"])
end
# DOM.div + add zstack class
# ZStack: holds more items, one active (on top) and the others hidden
# When a click event is trigered the active element can be changed by
# toggling the class 'active' from it's class list

# 1. Static Z-stack. Just the html, no click events (need to be added by hand)
zstack(item...; class="", style="", md=false) = wrap(item; class="zstack "*class, style=style)
active(item...; class="", style="", md=false) = wrap(item; class="active "*class, style=style)

# 2. Dinamic Z-stack, with active element selected by an observable with
#    range 1:height, where height defaults to 3 but can be modified
function zstack!(item...; observable=nothing, session=nothing, height=3, class="", style="", md=false) 
    if observable === nothing
        return zstack(item; class=class, style=style, md=md)
    else
        # static zstack
        item_div =  wrap(item; class="zstack "*class, style=style)

        # add on(observable) event
        onjs(session, observable, js"""function on_update(new_value) {
            const activefig_stack = $(item_div)
            for(i = 1; i <= $(height); ++i) {
                const element = activefig_stack.querySelector(":nth-child(" + i +")")
                element.classList.remove("active");
                if(i == new_value) {
                    element.classList.add("active");
                }
            }
        }
        """)
    end

    return item_div
end
# DOM.div + add hstack class => row of items
hstack(item...; class="", style="", md=false) = wrap(item; class="hstack "*class, style=style)
# DOM.div + add vstack class => col of items
vstack(item...; class="", style="", md=false) = wrap(item; class="vstack "*class, style=style)

# not tested yet
function classstack!(item; toggleclasses=[], observable=nothing, session=nothing, height=3, class="", style="", md=false) 
    if observable === nothing
        return item
    else

        # add on(observable) event
        onjs(session, observable, js"""function on_update(new_value) {
            const element = $(item)
            const cllist = $(toggleclasses)
            cllist.forEach((el) => {
                element.classList.remove(el);
            })
            element.classList.add(cllist[new_value-1]);
        }
        """)
    end

    return item
end