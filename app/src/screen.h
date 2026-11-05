#ifndef SCREEN_H
#define SCREEN_H

void   cls(void);
void   header(const char *title);
void   read_line(const char *prompt, char *buf, int len);
int    read_int(const char *prompt);
double read_money(const char *prompt);
void   pause_enter(void);
int    confirm(const char *prompt);

#endif
