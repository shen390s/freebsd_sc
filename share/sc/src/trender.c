#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

typedef char *(vget_t)(char *);

char *
consume_var(char *line) {
    char *p = line;

    if (!isalpha(*p)) {
        return p;
    }

    while ((*p) != 0x0) {
        if (isalnum(*p) || ((*p) == '_')) {
            p ++;
            continue;
        }
        break;
    }
    return p;
}

char *
skip_to_var_end(char *line) {
    char *p = line;

    while ((*p) != 0x0 ) {
        if ( (*p) == '\\') {
            if (*(p+1) == 0x0 ) {
                p ++;
            }
            else {
                p += 2;
            }
            continue;
        }

        if ( ((*p) == '%') && (*(p+1) == '%') ) {
            p += 2;
            break;
        }
    }

    return p;
}
    
int
render_line(char *line,
            vget_t *vg) {
    char  *p = line;
    char  *pstart = p;

    while ((*p) != 0x0) {
        if ((*p) == '\\') {
            fputc(*p, stdout);
            p ++;
            continue;
        }
        if (((*p) == '%') && (*(p+1) == '%')) {
            char *p1 = NULL;
            char var[128];

            p += 2;
            p1 = consume_var(p);
            memset(var, 0x0, sizeof(var));
            strncpy(var, p, p1 - p);
            fprintf(stdout, "%s", vg(var));

            p = skip_to_var_end(p1);
            continue;
        }

        fputc(*p, stdout);
        p ++;
    }
    
    return 0;
}

int
render_file(char *filename,
            vget_t *vg) {
    FILE *fp = NULL;
    char *line = NULL;
    size_t nsize = 0;
    int    rc = 0;

    fp = fopen(filename, "r");
    if (fp == NULL) {
        perror("fopen");
        return -1;
    }

    while (!feof(fp)) {
        if  (getline(&line, &nsize, fp) < 0) {
            if (!feof(fp)) {
                perror("getline");
                rc = -1;
                break;
            }
        }

        if (render_line(line, vg) < 0) {
            rc = -1;
            break;
        }
    }

    if (line != NULL) {
        free(line);
    }
    return rc;
}

static char *
my_vg(char *var) {
    char *p = getenv(var);

    if (p != NULL ) {
        return p;
    }

    return var;
}

int
main(int argc, char *argv[]) {
    int i;

    for (i = 1; i < argc; i ++) {
        render_file(argv[i], my_vg);
    }
    
    return 0;
}
