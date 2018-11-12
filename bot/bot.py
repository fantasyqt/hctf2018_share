import requests
from selenium import webdriver
import time

cookie = {'domain':'.2018.hctf.io','httponly':True,'name':'_hctf_session','path':'/','secure':False,'value':''}
# cookie's value must change your admin cookie
cookie['value']='e7JCv0Pctxu3mhICEX3pXfASwnE4ckGUWkxSPTMBUdEeXSqbHvrkrxoPtneOeHp6H4v%2BFeFB38kHSC%2BMFDLc5jDHiUwkkwsgtgdlrxd8%2F%2ByoJ4kt69FCLMl63NTUATxy9%2FdCh%2BnDWsuZSV0BopvvnAc6pToNkTj6F2WDmqXG1kXzlkYlWwRfGXRXecbI3pXoCTx4GOvPw4LowuS7b196QNr2PsCAKv0pnaU8--LLK3lTat8RbTRlvU--pYddOGJxUr1Vi%2F3lO98Z%2Bw%3D%3D'
driver=webdriver.PhantomJS()
driver.add_cookie(cookie)
driver.set_page_load_timeout(6)
driver.set_script_timeout(6)

while(True):
    driver.get('http://share.2018.hctf.io/recommend/show')
    time.sleep(0.75)
    if('Log in' in driver.page_source):
        break;
    else:
        print('[+]:running')
    #print(driver.page_source)

driver.quit()
