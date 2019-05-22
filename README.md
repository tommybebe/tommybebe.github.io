#### Contents
```python
class Me:
    def __init__(self, name):
        self.name = name
        self.features = []
        self.contacts = []
    
    def add_feature(self, new_feature):
        self.features.append(new_feature)
         
    def add_contact(self, contact_information):
        self.contacts.append(contact_information)
        
    def information(self):
        return [self.name, self.features[-1], self.contacts]
                
     
me = Me('이민우')

me.add_feature('예술가')
me.add_feature('가수')
me.add_feature('서비스 기획자')
me.add_feature('프론트엔드 개발자')
me.add_feature('데이터 분석가')

me.add_contact('email')
me.add_contact('blog')
me.add_contact('facebook')

print(me.information())
```
