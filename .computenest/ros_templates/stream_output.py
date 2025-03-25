import requests
import json

url = "http://120.26.120.66/v1/chat/completions"

payload = json.dumps({
  "model": "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B",
  "messages": [
    {
      "role": "user",
      "content": "<human>: 给定问题：交强险过期不上路会不会被罚？\n 检索结果：[1] 交强险过期不上路会不会被罚|法律分析：由于交强险是由保险公司对被保险机动车发生道路交通事故造成受害人(不包括本车人员和被保险人)的人身伤亡、财产损失，在责任限额内>予以赔偿的强制性责任保险。因此一旦交强险到期没续费，发生事故车主还会面临巨额赔偿。车险到期未交有处罚。法律依据：《机动车交通事故责任强制保险条例》 第三十八条 机动车所有人、管理人未按照规定投保机动车交通事故责任强制保险的，由公安机关交通管理部门扣留机动车，通知机动车所有人、管理人依照规定投保，处依照规定投保最低责任限额应缴纳的保险费的2倍罚款。 机动车所有人、管理人依照规定补办机动车交通事故责任强制保险的，应当及时退还机动车。<eod>\n请阅读理解上面多个检索结果，正确地回答问题。只能根据相关的检索结"
    }
  ],
  "max_tokens": 7000,
  "temperature": 0,
  "stream": True
})
headers = {
    'Content-Type': 'application/json',
    'Host': 'llm-model.llm-model.example.com' ,
    'Authorization': 'Bearer asdf123-'
}

response = requests.request("POST", url, headers=headers, data=payload)

curl -X POST "http://120.26.120.66/v1/chat/completions" -H "Host: llm-model.llm-model.example.com" -H "Content-Type: application/json" -H "Authorization: Bearer asdf123-" --data '{ "stream": true, "max_tokens": 1024, "temperature": 0, "model": "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B", "messages": [ { "role": "user", "content": "Tell me the recipe for tea" } ] }'