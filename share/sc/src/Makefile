TARGETS=tfrender
tfrender_SRCS=tfrender.c
tfrender_OBJS=$(tfrender_SRCS:.c=.o)

all: $(TARGETS)

tfrender: $(tfrender_OBJS)
	$(CC) -g -o $@ $(LDFLAGS) $(tfrender_OBJS)

.c.o:
	$(CC) -g -c $< $(CFLAGS)
clean::
	$(RM) -Rf $(TARGETS) *~ \
		$(tfrender_OBJS)
