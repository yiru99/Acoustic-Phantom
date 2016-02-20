
/* some includes */
#include <inttypes.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include <stdio.h>

#define BAUD 115200
#include <util/setbaud.h>

#define MIC_ADC_OFFSET  ((int)612)

#define ADC_PIN         0

void uart_init(void) {
   UBRR0H = UBRRH_VALUE;
   UBRR0L = UBRRL_VALUE;

#if USE_2X
   UCSR0A |= _BV(U2X0);
#else
   UCSR0A &= ~(_BV(U2X0));
#endif

   UCSR0C = _BV(UCSZ01) | _BV(UCSZ00); /* 8-bit data */
   UCSR0B = _BV(RXEN0) | _BV(TXEN0);   /* Enable RX and TX */
}

void uart_putchar(char c) {
   loop_until_bit_is_set(UCSR0A, UDRE0); /* Wait until data register empty. */
   UDR0 = c;
}

char uart_getchar(void) {
   loop_until_bit_is_set(UCSR0A, RXC0); /* Wait until data exists. */
   return UDR0;
}

FILE uart_output = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);
FILE uart_input = FDEV_SETUP_STREAM(NULL, uart_getchar, _FDEV_SETUP_READ);
FILE uart_io = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);

uint16_t adc_read(uint8_t adcx) {
   /* adcx is the analog pin we want to use.  ADMUX's first few bits are
    * the binary representations of the numbers of the pins so we can
    * just 'OR' the pin's number with ADMUX to select that pin.
    * We first zero the four bits by setting ADMUX equal to its higher
    * four bits. */
   ADMUX &= 0xf0;
   ADMUX |= adcx;

   /* This starts the conversion. */
   ADCSRA |= _BV(ADSC);

   /* This is an idle loop that just wait around until the conversion
    * is finished.  It constantly checks ADCSRA's ADSC bit, which we just
    * set above, to see if it is still set.  This bit is automatically
    * reset (zeroed) when the conversion is ready so if we do this in
    * a loop the loop will just go until the conversion is ready. */
   while (!(ADCSRA & _BV(ADIF)) );

   ADCSRA |= _BV(ADIF);

   /* Finally, we return the converted value to the calling function. */
   return ADCW;
}

void bargraphInit() {
   DDRD |= (1<<2) | (1<<3) | (1<<4) | (1<<5) | (1<<6) | (1<<7);
   DDRB |= (1<<2);
   DDRC |= (1<<3) | (1<<4) | (1<<5);

   PORTD &= ~((1<<2) | (1<<3) | (1<<4) | (1<<5) | (1<<6) | (1<<7));
   PORTB &= ~(1<<2);
   PORTC &= ~((1<<3) | (1<<4) | (1<<5));
}

void setBargraph(uint8_t level) {
   PORTD &= ~((1<<2) | (1<<3) | (1<<4) | (1<<5) | (1<<6) | (1<<7));
   PORTB &= ~(1<<2);
   PORTC &= ~((1<<3) | (1<<4) | (1<<5));
   if (level >= 0) PORTD |= (1<<7);
   if (level >= 1) PORTB |= (1<<2);
   if (level >= 2) PORTD |= (1<<6);
   if (level >= 3) PORTD |= (1<<5);
   if (level >= 4) PORTD |= (1<<4);
   if (level >= 5) PORTD |= (1<<3);
   if (level >= 6) PORTD |= (1<<2);
   if (level >= 7) PORTC |= (1<<3);
   if (level >= 8) PORTC |= (1<<4);
   if (level >= 9) PORTC |= (1<<5);
}

int main(void)
{
   ADCSRA |= ((1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0));    //Prescaler at 128 so we have an 125Khz clock source
   ADMUX |= (1<<REFS0);
   ADMUX &= ~(1<<REFS1); // AVCC as ref

   ADCSRA |= (1<<ADATE); // single source

   /* Enable the ADC */
   ADCSRA |= _BV(ADEN);

   /* Setup serial port */
   uart_init();
   stdout = &uart_output;
   stdin  = &uart_input;

   char input;

   // Setup ports
   DDRB |= (1<<1) | (1<<0);
   PORTB |= (1<<0);
   PORTB &= ~(1<<1);

   bargraphInit();

   /* Print hello and then echo serial
   ** port data while blinking LED */
   printf("Hello 549 TAs!!\r\n");

   // Demo to read sensor values
   int cnt = 2000;
   printf("Sensor Demo. Will print %d sensor values\r\n", cnt);
   while(1) {
      if (cnt == 0) {
         printf("Continue? [Y/n]\r\n");
         input = getchar();
         if (input == 'Y') break;
         cnt = 2000;
      }
      cnt--;
      printf("ADC val: %d\r\n", adc_read(ADC_PIN));
   }

   // Demo to control bar graph
   printf("Actuator Demo. Enter 0-9. Enter b to proceed to next demo.\r\n");
   while(1) {
      input = getchar();
      if (input == 'b') break;
      else if (input >= '0' && input <= '9') input = input - '0';
      else input = 0;

      setBargraph(input);
   }

   // Demo to for linked sensor and actuator
   int val;
   int old_val = 0;
   int val_lpf;

   while(1) {
      val = adc_read(ADC_PIN);
      val = val - MIC_ADC_OFFSET;
      if (val < 0) val = -val;

      val_lpf = val * 1 + old_val * 99;
      val_lpf = val_lpf / 100;
      old_val = val_lpf;

      setBargraph(val_lpf / 51);
      printf("%d\r\n", val_lpf);
   }

}
