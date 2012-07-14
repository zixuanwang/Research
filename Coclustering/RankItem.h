#pragma once
template <typename T1, typename T2>
class RankItem
{
public:
	RankItem(){}
	RankItem(T1 _index, T2 _value):index(_index),value(_value){}
	RankItem(const RankItem& rhs){
		index=rhs.index;
		value=rhs.value;
	}
	RankItem& operator=(const RankItem& rhs){
		index=rhs.index;
		value=rhs.value;
		return *this;
	}
	bool operator<(const RankItem& rhs) const{
		return value<rhs.value;
	}
	T1 index;
	T2 value;
};