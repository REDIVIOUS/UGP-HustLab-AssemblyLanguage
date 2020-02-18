#include <stdio.h>
#include <string.h>

extern void EDITIT(void); 
extern void CALCULATEREFER(void);
extern void RANKINGLEVEL(void);

struct shop
{
	char item[10]; //商品名 
	unsigned char discount; //折扣 
	short input;  //进价 
	short sell; //售价 
	short initem; //进货总数 
	short outitem; //已售数量
	short rec; //推荐度 
};


void search(struct shop *item)
{
	char a[10];
	int i=0;
	printf("PLEASE INPUT THE ITEM NAME(INPUT ENTER TO INPUT NAME)\n");
	scanf("%s",&a);
	if(strcmp(a,"")==0)
	{
		return;
	}
	for(i=0;i<8;i++)
	{
		if(strcmp(a,item[i].item)==0)
		{
			printf("\n");
			printf("ITEM NAME: %s\n",item[i].item);
			printf("DISCOUNT: %d\n",item[i].discount);
			printf("INPUT PRICE: %d\n",item[i].input);
			printf("SAILING PRICE: %d\n",item[i].sell);
			printf("TOTAL STOCK NUMBERS: %d\n",item[i].initem);
			printf("SOLD OUT NUMBERS: %d\n",item[i].outitem);
			printf("RECOMENDATION LEVEL: %d\n",item[i].rec);
			break;
		} 
	}
	if(i==8)
	{
		printf("\nDO NOT FIND THE ITEM!\n");
	} 
}

void OUT(struct shop *item,int recomend[10])
{
	int i=0;
	for(i=0;i<8;i++)
	{
		printf("ITEM NAME: %s\n",item[i].item);
		printf("RANK: %d\n",recomend[i]);
		printf("DISCOUNT: %d\n",item[i].discount);
		printf("INPUT PRICE: %d\n",item[i].input);
		printf("SAILING PRICE: %d\n",item[i].sell);
		printf("TOTAL STOCK NUMBERS: %d\n",item[i].initem);
		printf("SOLD OUT NUMBERS: %d\n",item[i].outitem);
		printf("RECOMEDATION LEVEL: %d\n",item[i].rec);
		printf("\n");
	}
}

void fm1(struct shop *item)
{
	char a[10];
	char dis;
	int i;
	short einput,esell,einitem,eoutitem;
	printf("PLEASE INPUT HE ITEM NAME(INPUT ENTER TO INPUT NAME)\n");
	scanf("%s",&a);
	getchar();
	for(i=0;i<8;i++)
	{
		if(strcmp(a,item[i].item)==0)
		{
			printf("DISCOUNT: %d->",item[i].discount);
			scanf("%c",&dis);
			item[i].discount=dis;
			printf("INPUT PRICE: %d->",item[i].input);
			scanf("%d",&einput);
			item[i].input=einput;
			printf("SAILING PRICE: %d->",item[i].sell);
			scanf("%d",&esell);
			item[i].sell=esell;
			printf("TOTAL STOCK NUMBERS: %d->",item[i].initem);
			scanf("%d",&einitem);
			item[i].initem=einitem;
			printf("SOLD OUT NUMBERS: %d->",item[i].outitem);
			scanf("%d",&eoutitem);
			item[i].outitem=eoutitem;
			break;
		} 
	}
	if(i==8)
	{
		printf("DO NOT FIND THE ITEM!\n");
	}
} 

void fm2(struct shop *item)
{
	int i=0;
	for(i=0;i<8;i++)
	{
		short a,b,c,d,f;
		a=item[i].input*128*10/(item[i].discount*item[i].sell);
		b=item[i].outitem*64/item[i].initem;
		c=a+b;
		item[i].rec=c; 
	}
}

void fm3(struct shop *item, int *recomend)
{
	short i,j;
	int a=1;
	struct shop temp;
	for(i=0;i<7;i++)
	{
		for(j=i+1;j<8;j++)
		{
			if(item[j].rec>item[i].rec)
			{
				temp=item[i];
				item[i]=item[j];
				item[j]=temp;
			}
		}
	}
	recomend[0] = a;
	for(i=0;i<7;i++)
	{
		if(item[i].rec!=item[i+1].rec)
			a++;
		recomend[i+1]=a;
	}
}

int main()
{
	struct shop item[8]={
		{"PEN",10,35,56,70,25,0},
		{"BOOK",9,35,56,70,25,0},
		{"PENCIL",9,50,30,25,5,0},
		{"BAG",9,50,80,60,20,0},
		{"TEXTBOOK",9,40,80,50,20,0},
		{"PAPER",9,5,10,50,30,0},
		{"GLUE",10,10,20,50,30,0},
		{"CANDY",9,2,4,60,40,0},
	};
	int num=0; 
	int auth=0;
	char username[10],password[10];
	int recomend[10];
	
	while(1)
	{
		printf("PLEASE INPUT THE NAME(INPUT ENTER TO LOOKUP, INPUT q TO QUIT)\n");
		gets(username);
		if(strcmp(username,"ABC")==0)
		{
			break;
		}
		else if(strcmp(username,"")==0)
		{
			goto MENU;
		}
		else if(strcmp(username,"q")==0)
		{
			goto EXIT;
		}
		else 
		{
			printf("WRONG NAME!\n");
		}
	}
	
	while(1)
	{
		printf("PLEASE INPUT THE PASSWORD\n");
		scanf("%s",password);
		if(strcmp(password,"ABC")==0)
		{ 
			auth=1; //转换登录状态 
			break;
		}
		else
		{
			printf("WRONG PASSWORD!\n");
		}
	} 
		
	MENU:
		while(1)
		{
			printf("\nPLEASE CHOOSE ONE FROM 1-6\n");
			printf("1=SEARCH THE IMFORMATION OF ITEMS\n");
			if(auth==1)
			{
				printf("2=EDIT THE IMFORMATION OF ITEM\n");
				printf("3=CALCULATE THE RECOMENDATION\n");
				printf("4=RANK THE RECOMENDATION\n");
				printf("5=OUTPUT THE IMFORMATION OF THE ITEM\n");
				
			}
			printf("6=EXIT\n\n");
			printf("INPUT THE NUMBER\n");
			scanf("%d",&num);
			if(num==1)
			{
				search(item);
				goto MENU;
			}
			else if(num==2)
			{
				EDITIT();
				goto MENU;
			}
			else if(num==3)
			{
				CALCULATEREFER(); 
				goto MENU;
			}
			else if(num==4)
			{
				RANKINGLEVEL();
				goto MENU;
			}
			else if(num==5)
			{
				OUT(item,recomend);
				goto MENU;	
			}
			else if(num==6)
			{
				goto EXIT;
			}
			else 
			{
				printf("INPUT THE WRONG NUMBER!");
			}
		}
		
	EXIT:
		return 0; 
 } 
