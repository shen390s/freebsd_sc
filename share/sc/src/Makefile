TARGETS=trender
trender_SRCS=trender.c
trender_OBJS=$(trender_SRCS:.c=.o)

all: $(TARGETS)

trender: $(trender_OBJS)
	$(CC) -g -o $@ $(LDFLAGS) $(trender_OBJS)

.c.o:
	$(CC) -g -c $< $(CFLAGS)
clean::
	$(RM) -Rf $(TARGETS) *~ \
		$(trender_OBJS)
